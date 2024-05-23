packages <- c("fastTextR")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(fastTextR)

model <- ft_load("../pretrained_models/cc.en.300.bin")