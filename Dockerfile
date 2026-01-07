# -------- Build stage: render Quarto site --------
FROM rocker/r-ver:4.4.2 AS quarto-build

RUN apt-get update && apt-get install -y \
    wget \
    pandoc \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN wget https://quarto.org/download/latest/quarto-linux-amd64.deb \
    && dpkg -i quarto-linux-amd64.deb \
    && rm quarto-linux-amd64.deb

WORKDIR /site
COPY . .

# Render all .qmd pages into a single site
RUN quarto render

# -------- Runtime stage: serve static site --------
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=quarto-build /site/_site /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
