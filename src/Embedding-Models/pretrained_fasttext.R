packages <- c("fastTextR")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(fastTextR)

model <- ft_load("../pretrained_models/crawl-300d-2M-subword.bin")