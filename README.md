# DSA Visualizer

A project designed to help people understand Data Structures and Algorithms better. Built with the **Godot engine**.

**Note:** This project is currently in development. Using the Godot engine opens up the possibility of exporting this "game" to a website, making it more accessible.

---

## 🌲 Binary Search Tree (BST)

![Bin Tree gif](video/Bin_Tree_Example.gif)

### ✅ Implemented Features

* Full visualization for the tree structure.
* Functionality to **add**, **delete**, and **search** for nodes.
* Nodes dynamically reorder themselves upon modification.

### 🚀 Next Steps

* Implement BST traversal algorithms: **Pre-order**, **In-order**, and **Post-order**.
* Develop an interactive "Learning Mode" that quizzes the user on the correct steps for various operations.
* **Big Task:** Expand to include more complex trees, such as **Splay Trees**, **B-Trees**, and **Red-Black Trees**.

---

## 🌐 Graph

![Graph gif](video/Graph_example.gif)

### ✅ Implemented Features

* A **physics-based graph simulation** implemented in C# for better performance (running on the CPU).
* Capable of handling ~40 nodes smoothly on most computers, which is ample for learning purposes.
* Nodes can be clicked and **dragged**, with physics forces persisting.
* Dynamic adjustment of physics forces (e.g., center attraction and node repulsion).

### 🚀 Next Steps

* Implement **spring-like forces for edges** to better manage the layout (pulling connected nodes together).
* Add functionality to **highlight** specific nodes and edges (e.g., to show a path).
* Add a "manual mode" to **disable physics** and allow static placement of nodes in desired positions.

### 🎯 Algorithms to Visualize

Once the core graph visualization is stable, the following algorithms will be implemented:

* DFS (Depth-First Search)
* BFS (Breadth-First Search)
* Bellman-Ford
* Dijkstra's Algorithm
* Prim's Algorithm
* Topological Sort

---

## 🎨 General Future Goals

My current priority is core functionality. Once that is robust, the focus will shift to aesthetics and user experience.

* Design and implement polished, user-friendly menus to make the learning tool more enjoyable.
* Refine and improve the animations for all data structure operations.
* Improve the overall graphical style and assets.