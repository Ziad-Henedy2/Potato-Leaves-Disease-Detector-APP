import os
import io
import base64
import numpy as np
import re
import cv2
import tensorflow as tf
import datetime
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing import image
import firebase_admin
from firebase_admin import credentials, firestore
from flask import Flask, request, jsonify
from flask_cors import CORS
from supabase import create_client
from PIL import Image as PILImage
#creating report needs
import google.generativeai as genai
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image as PDFImage, ListFlowable, ListItem
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.units import inch
from reportlab.lib import colors

# Initialize Flask App
app = Flask(__name__)
CORS(app)  # Enable CORS

# Initialize Firebase
cred = credentials.Certificate("gradproject-34e48-firebase-adminsdk-fbsvc-a05078ffb8.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Configure Gemini AI

genai.configure(api_key="AIzaSyC0fd07-c0Yqs0BXqwzBSo_q7sqPbNVpPA")

models = genai.list_models()
for model in models:
    print(model.name)


# Load Model
model2 = tf.keras.models.load_model("potato_disease_final4.keras")
disease_classes = ["Alternaria Solani", "Healthy", "Insect Damage", "Phytophthora Infestans", "Virus"]

# Initialize Supabase
SUPABASE_URL = "https://eiriudtlrtygqxfdjchc.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpcml1ZHRscnR5Z3F4ZmRqY2hjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjU3MDg3NiwiZXhwIjoyMDU4MTQ2ODc2fQ.-gBPmAaBgyvPYQ7K6dcoqQL9SoEgC88rbMU6AxINSzs"
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def generate_heatmap(image_path, model, class_idx, layer_name="conv4_block6_out", alpha=0.5):
    try:
        # Load and preprocess image
        img = image.load_img(image_path, target_size=(224, 224))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array /= 255.0
        # Create a model that maps input to the target layer and output
        grad_model = Model(inputs=model.input, outputs=[model.get_layer(layer_name).output, model.output])

        with tf.GradientTape() as tape:
            conv_outputs, predictions = grad_model(img_array)
            loss = predictions[:, class_idx]

        grads = tape.gradient(loss, conv_outputs)

        if grads is None:
            raise ValueError("Gradients are None! Check layer name and model structure.")

        if len(grads.shape) == 3:
            grads = tf.expand_dims(grads, axis=0)

        pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

        conv_outputs = conv_outputs[0].numpy()
        for i in range(pooled_grads.shape[0]):
            conv_outputs[:, :, i] *= pooled_grads[i]

        heatmap = np.mean(conv_outputs, axis=-1)
        heatmap = np.maximum(heatmap, 0)
        heatmap /= np.max(heatmap)

        # Resize and colorize heatmap
        heatmap_resized = cv2.resize(heatmap, (224, 224))
        heatmap_resized = cv2.GaussianBlur(heatmap_resized, (5, 5), 0)
        heatmap_resized = np.uint8(255 * heatmap_resized)
        heatmap_colored = cv2.applyColorMap(heatmap_resized, cv2.COLORMAP_JET)

        # Superimpose on original image
        orig_img = cv2.imread(image_path)
        orig_img = cv2.resize(orig_img, (224, 224))
        superimposed_img = cv2.addWeighted(orig_img, 1 - alpha, heatmap_colored, alpha, 0)

        # Save result
        os.makedirs("heatmaps", exist_ok=True)
        heatmap_path = f"heatmaps/heatmap_{datetime.datetime.now().timestamp()}.jpg"
        cv2.imwrite(heatmap_path, superimposed_img)

        return heatmap_path
    except Exception as e:
        return str(e)

def get_disease_info(disease_name):
    try:
        model = genai.GenerativeModel("gemini-1.5-pro")  # Use an available model name
        response = model.generate_content(f"Provide information about {disease_name} in detail.")
        return response.text if hasattr(response, "text") else "No response generated."
    except Exception as e:
        print(f"❌ Error in get_disease_info: {str(e)}")
        return "Error fetching disease information."


def create_pdf(user_data, original_img, heatmap_img, disease_info, disease_name):
    pdf_path = f"reports/{user_data['name']}_{datetime.datetime.now().timestamp()}.pdf"
    doc = SimpleDocTemplate(pdf_path, pagesize=letter,
                            rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=30)
    styles = getSampleStyleSheet()

    # Custom styles
    styles.add(ParagraphStyle(name='SectionTitle', fontSize=14, leading=18, spaceAfter=10, textColor=colors.HexColor("#2F4F4F"), alignment=1))
    styles.add(ParagraphStyle(name='SubTitle', fontSize=12, leading=14, textColor=colors.HexColor("#4682B4")))
    styles.add(ParagraphStyle(name='CustomBullet', fontSize=10, leading=12, leftIndent=10))
    styles.add(ParagraphStyle(name='CenteredHeading3',parent=styles['Heading3'],alignment=TA_CENTER))

    elements = []

    # Absolute image paths
    original_img = os.path.abspath(original_img)
    heatmap_img = os.path.abspath(heatmap_img)
    assert os.path.exists(original_img), f"Error: {original_img} not found!"
    assert os.path.exists(heatmap_img), f"Error: {heatmap_img} not found!"

    # Header
    elements.append(Paragraph("Potato Leaf Disease Diagnosis Report", styles['Title']))
    elements.append(Spacer(1, 12))

    # User Info Table
    user_data_table = [
        ["User Name", user_data['name']],
        ["Email", user_data['email']],
        ["Location", user_data['location']],
        ["Report Date", datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')],
        ["Predicted Disease", f"{disease_name}"]
    ]
    table = Table(user_data_table, colWidths=[1.7*inch, 4.8*inch])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('BACKGROUND', (0, 1), (-1, -1), colors.whitesmoke),
        ('GRID', (0, 0), (-1, -1), 0.3, colors.grey),
    ]))
    elements.append(table)
    elements.append(Spacer(1, 20))

    # Images with Labels
    image_section = Table([
        [Paragraph("Original Image", styles['CenteredHeading3']),Paragraph("Heatmap Image", styles['CenteredHeading3'])],
        [PDFImage(original_img, width=2.5*inch, height=2*inch),PDFImage(heatmap_img, width=2.5*inch, height=2*inch)]
    ], colWidths=[3.5*inch, 3.5*inch])

    image_section.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
    ]))

    elements.append(image_section)
    elements.append(Spacer(1, 24))

    # Diagnosis & AI Output Section
    elements.append(Paragraph("Disease Analysis", styles['SectionTitle']))
    elements.append(Spacer(1, 10))

    lines = disease_info.strip().split("\n")
    current_list = []
    in_list = False

    for line in lines:
        line = line.strip()

        # Skip empty lines
        if not line:
            continue

        # Markdown-style title (## Title)
        if line.startswith("## "):
            if in_list:
                elements.append(ListFlowable(current_list, bulletType='bullet'))
                current_list = []
                in_list = False
            title = line.replace("## ", "").strip()
            elements.append(Paragraph(f"<b><font size=14>{title}</font></b>", styles['Heading1']))
            elements.append(Spacer(1, 8))

        # Roman numerals (I. II. III.)
        elif re.match(r"^[IVXLCDM]+\.", line):
            if in_list:
                elements.append(ListFlowable(current_list, bulletType='bullet'))
                current_list = []
                in_list = False
            elements.append(Paragraph(f"<b><font size=12>{line}</font></b>", styles['Heading2']))
            elements.append(Spacer(1, 6))

        # Bold headings (**Title**)
        elif line.startswith("**") and line.endswith("**"):
            if in_list:
                elements.append(ListFlowable(current_list, bulletType='bullet'))
                current_list = []
                in_list = False
            section_title = line.replace("**", "").strip()
            elements.append(Paragraph(f"<b><font size=12>{section_title}</font></b>", styles['Heading2']))
            elements.append(Spacer(1, 6))

        # List with bold inline label (**Chewing:** ...)
        elif re.match(r"^[*•]\s*\*\*(.+?)\*\*[:：]?", line):
            in_list = True
            clean = re.sub(r"^[*•]\s*", "", line)
            # Replace only the first pair of '**' with <b> and </b>
            clean = clean.replace("**", "<b>", 1).replace("**", "</b>", 1)
            current_list.append(ListItem(Paragraph(clean, styles['BodyText'])))

        # Basic bullet list (* or •)
        elif line.startswith("*") or line.startswith("•"):
            in_list = True
            clean = line.lstrip("*• ").strip()
            current_list.append(ListItem(Paragraph(clean, styles['BodyText'])))

        # Regular paragraph
        else:
            if in_list:
                elements.append(ListFlowable(current_list, bulletType='bullet'))
                current_list = []
                in_list = False
            elements.append(Paragraph(line, styles['BodyText']))
            elements.append(Spacer(1, 6))

    # If any list remains unclosed
    if in_list and current_list:
        elements.append(ListFlowable(current_list, bulletType='bullet'))
        elements.append(Spacer(1, 10))

    doc.build(elements)
    return pdf_path

def upload_to_supabase(pdf_path, user_id):
    with open(pdf_path, "rb") as f:
        file_name = os.path.basename(pdf_path)
        supabase.storage.from_("classified-reports").upload(file_name, f,file_options={"content-type": "application/pdf"})
    return f"{SUPABASE_URL}/storage/v1/object/public/classified-reports/{file_name}"


@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "No file"}), 400
    file = request.files["file"]
    image = PILImage.open(io.BytesIO(file.read())).convert("RGB")
    image = image.resize((224, 224))
    image = np.array(image) / 255.0
    image = np.expand_dims(image, axis=0)
    prediction = model2.predict(image)
    disease = disease_classes[np.argmax(prediction)]
    return jsonify({"disease": disease})


@app.route("/generate_report", methods=["POST"])
def generate_report():
    try:
        data = request.get_json()
        print("✅ Received JSON:", data)  # Debugging
        if "image_base64" in data:
            print("Base64 Image (First 100 chars):", data["image_base64"][:100])
        if "user_data" in data:
            print("User Data:", data["user_data"])
        # In generate_report route after generating paths:

        user_data = data["user_data"]
        disease_name = data["disease_name"]
        base64_image = data["image_base64"]

        print(f"Debug: user_data received - {user_data}")

        # Decode and save image
        image_filename = f"uploaded_{user_data['name']}.jpg"
        image_path = os.path.join("uploads", image_filename)
        os.makedirs("uploads", exist_ok=True)

        with open(image_path, "wb") as image_file:
            image_file.write(base64.b64decode(base64_image))
        print(f"✅ Image saved at: {image_path}")

        # Generate heatmap
        try:
            disease_idx = disease_classes.index(disease_name)
            heatmap_path = generate_heatmap(image_path, model2, disease_idx)
            print(f"✅ Heatmap generated: {heatmap_path}")
        except Exception as e:
            print(f"❌ Error in generate_heatmap: {str(e)}")
            return jsonify({"error": f"Heatmap generation failed: {str(e)}"}), 500

        # ===== ADD THE VALIDATION HERE =====
        if not os.path.exists(heatmap_path):
            return jsonify({"error": "Heatmap image missing"}), 500
        if not os.path.exists(image_path):
            return jsonify({"error": "Original image missing"}), 500

        # Get disease info
        try:
            disease_info = get_disease_info(disease_name)
            print(f"✅ Disease info fetched: {disease_info}")
        except Exception as e:
            print(f"❌ Error in get_disease_info: {str(e)}")
            return jsonify({"error": f"Disease info retrieval failed: {str(e)}"}), 500

        # Create PDF
        try:
            pdf_path = create_pdf(user_data, image_path, heatmap_path, disease_info, disease_name)
            print(f"✅ PDF created: {pdf_path}")
        except Exception as e:
            print(f"❌ Error in create_pdf: {str(e)}")
            return jsonify({"error": f"PDF generation failed: {str(e)}"}), 500

        # Upload PDF to Supabase
        try:
            report_url = upload_to_supabase(pdf_path, data["user_id"])
            print(f"✅ Report uploaded: {report_url}")
        except Exception as e:
            print(f"❌ Error in upload_to_supabase: {str(e)}")
            return jsonify({"error": f"Upload to Supabase failed: {str(e)}"}), 500

        return jsonify({"report_url": report_url}), 200

    except Exception as e:
        print(f"❌ General error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
