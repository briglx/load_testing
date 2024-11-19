"""Example app for rest api."""

import logging
import os
import random
import time

from flask import Flask, jsonify, request

# Initialize the Flask app
app = Flask(__name__)

RELEASE_VERSION = os.getenv("RELEASE_VERSION", "unknown")

# Folder where uploaded files will be saved
UPLOAD_FOLDER = "./uploads"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

logger.info("Release version: %s", RELEASE_VERSION)


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    logger.info("Health check endpoint")
    return jsonify({"status": "ok", "release_version": RELEASE_VERSION})


# Test route for load testing. Random response time between 0 and 2 seconds.
@app.route("/test", methods=["GET"])
def test():
    """Test route for load testing."""
    delay = random.randint(0, 3)
    time.sleep(delay)
    return jsonify({"status": "ok", "release_version": RELEASE_VERSION, "delay": delay})


# API route to upload a file with associated metadata
@app.route("/upload", methods=["POST"])
def upload_file():
    """Upload a file with associated metadata."""
    if "file" not in request.files:
        logger.error("No file part in the request")
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files["file"]

    if file.filename == "":
        logger.error("No selected file")
        return jsonify({"error": "No selected file"}), 400

    # Save file to the upload folder
    if file:
        try:
            file_path = os.path.join(app.config["UPLOAD_FOLDER"], file.filename)
            file.save(file_path)
            logger.info("File %s uploaded successfully", file.filename)

            # Retrieve metadata from form
            metadata = request.form.to_dict()

            # Example: return a success message with metadata and file details
            response = {
                "message": "File successfully uploaded",
                "file_name": file.filename,
                "metadata": metadata,
            }
            logger.info(response)
            return jsonify(response), 200
        except Exception as e:  # pylint: disable=W0718
            logger.error("Error uploading file: %s", e)
            return jsonify({"error": str(e)}), 500

    return jsonify({"error": "Unknown error"}), 500


# # Run the Flask app
# if __name__ == "__main__":
#     logger.info("Release version: %s", RELEASE_VERSION)
#     app.run(debug=True, host="0.0.0.0")
