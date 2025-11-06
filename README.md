Question 1:
As dimensions start ti increase, the clusters can be slightly closer together before the gap statistic fails to identify them correctly. This happens because in higher dimensions, clusters have more "space" to spread out and remain distinguishable even with smaller side lengths. 
However, once the side length drops below a certain threshold for each dimension, the clusters overlap too much, and the gap statistic consistently begins to underestimate the true number of clusters.

dim: 2 3 4 5 6
clusters: 2 3 4 5 6
fails at: 2 3 3 3.5 3.5
respectively

Question 2:
Failure Point Explanation:
As the maximum radius gets smaller, the shells become too close together, and spectral clustering starts to merge them. When points from neighboring shells fall within the distance threshold (d = 1.0), the algorithm treats them as connected and can no longer tell the shells apart. This is where the method fails and begins to underestimate the number of clusters.

Effect of Distance Threshold:
If the distance threshold were smaller (d = 0.8), the algorithm would fail sooner because fewer points would be considered connected. If it were larger (d = 1.2), the clusters would merge earlier since points from different shells would link more easily.
