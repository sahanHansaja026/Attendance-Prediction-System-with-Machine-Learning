# 1. Use Python 3.11 base image
FROM python:3.11-slim

# 2. Install build tools (needed for some packages)
RUN apt-get update && apt-get install -y build-essential curl

# 3. Install Rust (for packages like pydantic-core if needed)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 4. Set working directory
WORKDIR /app

# 5. Copy project files
COPY . /app

# 6. Upgrade pip and install requirements
RUN pip install --upgrade pip
RUN pip install --prefer-binary -r requirements.txt

# 7. Expose default container port (not Render port)
EXPOSE 8000

# 8. Run FastAPI (Use Render-assigned port)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]
