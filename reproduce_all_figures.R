# =============================================================================
# reproduce_all_figures.R
# Reproduz TODOS os gráficos do artigo usando apenas o pacote logcumulant.
#
# Uso:
#   1) Instale o pacote:
#        install.packages("logcumulant_0.1.0.tar.gz", repos = NULL, type = "source")
#   2) Rode este script:
#        Rscript reproduce_all_figures.R
#   Os PDFs serão gravados em ./figuras_reproduzidas/
# =============================================================================

suppressMessages({
  library(logcumulant)
  library(ggplot2)
  library(gridExtra)
})

outdir <- "figuras_reproduzidas"
dir.create(outdir, showWarnings = FALSE)

# Dados embutidos no pacote (9 datasets de confiabilidade)
data(reliability_datasets)
RD <- reliability_datasets

nicelab <- c(Kevlar = "Kevlar", Resistors = "Resistors",
             Tensile = "Tensile Strength", Airplane = "Airplane Window",
             BallBearing = "Ball Bearing", Airborne = "Airborne",
             Failure = "Failure Time", Yarn = "Yarn",
             AirCon = "Air Conditioning")

# Bootstrap adaptativo por tamanho amostral (como no artigo)
adB <- function(n) if (n <= 50) 1999 else if (n <= 100) 999 else 499

# ---- 1) Os 3 diagramas (individuais + painel) para os 9 datasets -----------
for (nm in names(RD)) {
  x <- RD[[nm]]; B <- adB(length(x)); lab <- nicelab[nm]
  p1 <- log_cumulant_diagram(x, lab, B = B)
  p2 <- kurtosis_diagram(x, lab, B = B)
  p3 <- cv_diagram(x, lab, B = B)
  ggsave(file.path(outdir, paste0(nm, "_a_lc.pdf")),       p1, width = 6.5, height = 5.2, device = cairo_pdf)
  ggsave(file.path(outdir, paste0(nm, "_b_kurtosis.pdf")), p2, width = 6.5, height = 5.2, device = cairo_pdf)
  ggsave(file.path(outdir, paste0(nm, "_c_cv.pdf")),       p3, width = 6.5, height = 5.2, device = cairo_pdf)
  ggsave(file.path(outdir, paste0(nm, "_panel.pdf")),
         arrangeGrob(p1, p2, p3, ncol = 3), width = 19.5, height = 5.5, device = cairo_pdf)
  cat("diagramas:", nm, "\n")
}

# ---- 2) Figura 1: curvas teóricas e multi-dataset --------------------------
# (a) curvas teóricas coloridas + (b) com nuvens de 3 datasets (fill+shape)
p_multi <- multi_lc_diagram(RD[c("Airplane", "BallBearing", "Yarn")],
                            dataset_names = c("Airplane", "BallBearing", "Yarn"),
                            B = 1000)
ggsave(file.path(outdir, "Fig1b.pdf"), p_multi, width = 8, height = 5.5, device = cairo_pdf)
cat("Figura 1b (multi_lc_diagram)\n")

# ---- 3) plot.lc (interface pedida pelo revisor) ----------------------------
ggsave(file.path(outdir, "plot_lc_example.pdf"),
       plot.lc(RD$BallBearing, B = 100), width = 6.5, height = 5.2, device = cairo_pdf)

cat("\nConcluído. Veja a pasta", outdir, "\n")
cat("Observação: as curvas de potência (Figura 3) são geradas pelos scripts\n",
    "de simulação em ../BACKUP/scripts/ (size_study, power_study e variações),\n",
    "pois dependem de simulação Monte Carlo, não de um único dataset.\n")
