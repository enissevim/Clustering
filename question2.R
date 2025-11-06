library(cluster)
library(ggplot2)
library(plotly)

generate_shell_clusters <- function(n_shells, k_per_shell, max_radius, noise_sd = 0.1) {
  radii <- seq(max_radius / n_shells, max_radius, length.out = n_shells)
  X <- NULL
  for (i in 1:n_shells) {
    phi <- runif(k_per_shell, 0, 2 * pi)
    theta <- runif(k_per_shell, 0, pi)
    r <- radii[i] + rnorm(k_per_shell, 0, noise_sd)
    x <- r * sin(theta) * cos(phi)
    y <- r * sin(theta) * sin(phi)
    z <- r * cos(theta)
    X <- rbind(X, cbind(x, y, z))
  }
  return(X)
}

spectral_cluster <- function(x, k, d_threshold = 1) {
  n <- nrow(x)
  dist_matrix <- as.matrix(dist(x))
  A <- (dist_matrix < d_threshold) * 1
  A <- (A + t(A)) / 2
  diag(A) <- 0
  
  d <- rowSums(A)
  D_inv_sqrt <- diag(1 / sqrt(pmax(d, 1e-12)))
  L_sym <- diag(n) - D_inv_sqrt %*% A %*% D_inv_sqrt
  
  eig <- eigen(L_sym, symmetric = TRUE)
  idx <- order(eig$values)
  U <- eig$vectors[, idx[1:k], drop = FALSE]
  U <- U / sqrt(rowSums(U^2) + 1e-12)
  
  km <- kmeans(U, centers = k, nstart = 100, iter.max = 500)
  return(list(cluster = km$cluster))
}

sample_data <- generate_shell_clusters(4, 100, 5)
plot_ly(
  x = sample_data[, 1], y = sample_data[, 2], z = sample_data[, 3],
  type = "scatter3d", mode = "markers",
  marker = list(size = 2, color = rep(1:4, each = 100))
)

max_radii <- 10:1
results <- data.frame()

for (R in max_radii) {
  X <- generate_shell_clusters(4, 100, R, noise_sd = 0.1)
  
  gap <- tryCatch({
    clusGap(X,
            FUN = function(xx, kk) spectral_cluster(xx, kk, d_threshold = 1),
            K.max = 4,
            B = 20)
  }, error = function(e) NULL)
  
  if (!is.null(gap)) {
    est <- maxSE(gap$Tab[, "gap"], gap$Tab[, "SE.sim"])
  } else {
    est <- NA 
  }
  
  results <- rbind(results, data.frame(max_radius = R, estimated_clusters = est))
}

p <- ggplot(results, aes(max_radius, estimated_clusters)) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = 4, linetype = "dashed", color = "orange") +
  labs(
    x = "Max Radius",
    y = "Est. Clusters",
    title = "Spectral Clustering"
  ) +
  theme_minimal()

print(p)

ggsave("question2_plot.png")
write.csv(results, "question2_results.csv", row.names = FALSE)