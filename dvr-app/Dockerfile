# Use official Python image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements file if exists
COPY requirements.txt ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt || true

# Copy application code
COPY . .

# Set default command (update 'app.py' as needed)
CMD ["python", "app.py"]