Master all graph theory concepts for IBDP HL Math!

**Important Updates**
Currently, the textbook features have been disabled due to an issue with Cocoapods.
This feature will be added back in the near future.

1. Overview
  This is an educational app designed to teach graph theory concepts to IBDP students, or anyone interested in graph theory.
2. Algorithms
   - Kruskal's and Prim's algorithms for finding minimum spanning trees
   - Prim's algorithm applied to a weighted adjacency table
   - The Chinese Postman problem
   - The Traveling Salesman problem
4. Features
   - Pre-built graphs for immediately practicing graph theory algorithms
   - Canvas: The canvas allows users to create their own custom graphs,
     and select any of the available algorithms to practice solving each type of problem.
     This is great for if you're trying to solve a unique graph theory problem,
     and need to verify that you're correctly applying the algorithm.
5. Using the Canvas
   - Create a vertex: Click anywhere on the canvas to place a vertex. Vertices are automatically labelled as they're created.
   - Create an edge: Click first on a starting vertex, and the vertex will become hilighted in green.
     Then click on an ending vertex. An edge will be constructed between those two vertices.
   - Delete a vertex or edge by double-clicking on it.
   - Change an edge's shape: Click and drag on any edge to add a curve to its shape.
   - Add weights: Click the checkbox at the top of the canvas to show weights. Default weights of 0 will
     be applied to all edges.
   - Change weights: Changing a weight is as simple as clicking on the number, inputting the
     new weight into the textbox, and pressing Enter. The weight and the edge will both
     change to blue so you know you're modifying the correct edge.
   - Move weights around: Click and drag on a weight to reposition it relative to its edge.
   - Clear the canvas: Click the "Clear" button in the top right to reset your work.
   - Apply an algorithm: After designing your graph, select an algorithm from the drop-down menu.
     See the Using Algorithms section on how to implement each algorithm on your graph.
6. Using Algorithms
   - Kruskal's Algorithm - Start by selecting the edge with the lowest weight. The edge will change to green
     to indicate a correct selection. Of the edges that remain, continue to select the lowest
     weighted edge. Ensure that any subgraphs created do not create any cycles.
     If you make a mistake, the edge will turn red and a description of the error will appear
     in the top-left corner of the screen. Unselect the incorrect edge, and it will return to
     its default color. When you successfully complete the algorithm, the background color
     will change to blue.
   - Prim's Algorithm - The usage of Prim's Algorithm is generally the same as Kruskal's Algorithm,
     with one important difference. The first move is to select a starting vertex. Then,
     select the lowest weight edge connected to that vertex. Continuing choosing
     lowest weight edges among those currently adjacent to your subgraph.
   - Chinese Postman Problem - Start by selecting the starting vertex. Then select edges
     in the correct order according to the algorithm. The edges will change color
     based on how many times they have been selected. An edge chosen once will appear
     green, twice will appear blue, and three times will appear dark magenta.
     The background will change to blue when the algorithm is completed successfully.
   - The Traveling Salesman Problem - There are several stages to this algorithm. Start by
     selecting your starting verte. Then apply the nearest neighbor algorithm by selecting
     edges in the correct order. The vertices will change color to keep track of
     where you have traveled. When finished, you'll need to apply the deleted vertex
     algorithm. Double click any vertex to delete it. Then, apply Kruskal's algorithm
     by selecting edges in the correct order. When finished, click again on the
     vertex that you deleted to restore it. Finally, add back the two edges
     with the smallest weights. Calculations for the lower and upper bounds will
     be displayed upon successful completion.
7. Upcoming Features
   - Future updates will introduce new features, and add depth to the program's
     current capabilities. These include:
     - A complete and interactive textbook that will teach all graph theory
       topics in the IBDP HL math curriculum.
     - Additional textbook practice problems for all related graph theory algorithms.
     - Practice IBDP exam questions
     
