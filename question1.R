library(cluster)
library(tidyverse)
library(plotly)

generate_hypercube_clusters <- function(n, k, side_length, noise_sd = 1.0) {
  centers <- diag(n) * side_length
  X <- NULL
  for(i in 1:n) {
    cluster_points <- matrix(rnorm(k * n, mean = centers[i,], sd = noise_sd), 
                             ncol = n, byrow = TRUE)
    X <- rbind(X, cluster_points)
  }
  return(X)
}

dimensions <- c(6, 5, 4, 3, 2)
side_lengths <- 10:1
k <- 100
noise_sd <- 1.0
results <- data.frame()

for(n in dimensions) {
  for(side_length in side_lengths) {
    data <- generate_hypercube_clusters(n, k, side_length, noise_sd)
    gap <- clusGap(data, FUN = kmeans, K.max = n, B = 50, 
                   nstart = 20, iter.max = 50)
    best_k <- maxSE(gap$Tab[, "gap"], gap$Tab[, "SE.sim"])
    results <- rbind(results, data.frame(
      dimension = n,
      side_length = side_length,
      estimated_clusters = best_k,
      true_clusters = n
    ))
  }
}

ggplot(results, aes(x = side_length, y = estimated_clusters, group = dimension, color = factor(dimension))) +
  geom_line() +
  geom_point() +
  geom_hline(aes(yintercept = true_clusters), linetype = "dashed", color = "black") +
  labs(
    x = "Side Length",
    y = "Estimated Number of Clusters",
    color = "Dimension"
  )

ggsave("question1_plot.png")
write.csv(results, "question1_results.csv")