FROM python:3.9-slim

WORKDIR /app

# Separate the installation of dependencies from the rest of the code to optimize Docker caching
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "-m", "puppy_pics.main"]
