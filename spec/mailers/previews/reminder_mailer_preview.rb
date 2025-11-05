class ReminderMailerPreview < ActionMailer::Preview
  def due_notes_email
    user = User.first.id
    notes = generate_content
    ReminderMailer.with(user:, notes:).due_notes_email
  end

  private

  def generate_content
    content = []
    content << "$$\int_a^x f(t)\,dt = F(x) - F(a)$$"
    content << "**Additivity**: $T(u + v) = T(u) + T(v)$\n2. **Homogeneity(scaling)**: $T(cu) = cT(u)$\n\n ### The Bridge Between Matrix and Functions"
    content << "**Dot Product**: The dot product is calculated by multiplying corresponding components of the vectors and summing the results. - $a \cdot b = \sum a_ib_i$"
    content << "This is inline math: \(x^2 + x + 1 = 0\). This equation is often called the golden equation."
    content << "The equation \$E=mc^2\$ is famous"
    content << "This sentence uses $\` and \`$ delimiters to show math inline: $`\sqrt{3x-1}+(1+x)^2`$"
    content << 'Formula
    $$
    \begin{aligned}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{aligned}
$$.'
    content << "## Linear Algebra

**Vectors**
- Represent _features_, predictions and model parameters
- Operations
  - **Addition**: Vector addition combines two vectors by adding their corresponding components, resulting in a new vector.
    - $a + b = (a_1 + b_1,\cdots, a_n + b_n)$
  - **Scalar multiplication**: Scalar multiplication scales a vector by a constant, changing its magnitude but not its direction
    - $k\cdot v = (kv_1, \cdots,k_n)$
  - **Dot Product**: The dot product is calculated by multiplying corresponding components of the vectors and summing the results.
    - $a \cdot b = \sum a_ib_i$"
    content << "## Matrices and Functions - The Connection

In **linear algebra**, a matrix is one way to represent a specific kind of function -- specifically a **linear function** (or **linear transformation**).

A **linear transformation** is a function: $T : \R^n \rightarrow \R^n$ that satisfies two properties for all vectors u, v and scalar c:

1. **Additivity**: $T(u + v) = T(u) + T(v)$
2. **Homogeneity(scaling)**: $T(cu) = cT(u)$

### The Bridge Between Matrix and Functions
When we chose a **basis** for our vector spaces, any linear transformation _**T**_ can be represented by a **matrix** _A_ such that: $T(x) = Ax$. So, while the matrix itself isn't the function, it's a representation of that function -- a concrete way to compute the output.

### Example: Matrix as Functions
Let:
$
A =
\begin{bmatrix}
2 & 0 \\
0 & 3
\end{bmatrix}
$

Define the function:
$
T(\mathbf{x}) = A\mathbf{x}
$

If
$
\mathbf{x} = \begin{bmatrix} 1 \\ 2 \end{bmatrix}
$
then:

$
T(\mathbf{x}) =
\begin{bmatrix}
2 & 0 \\
0 & 3
\end{bmatrix}
\begin{bmatrix}
1 \\ 2
\end{bmatrix} =
\begin{bmatrix}
2 \\ 6
\end{bmatrix}
$

So here:
- the **function** is 'scale _x_ by 2 and _y_ by 3'
- the **matrix** is its representation -- it encodes the same operation numerically

### Why We Say 'A Matrix is a Function'
When we say, 'the matrix transforms space', we really mean the 'the **linear function** represented by this matrix transforms space."
    content << "## Matrices and Functions - The Connection\n\nIn **linear algebra**, a matrix is one way to represent a specif
ic kind of function -- specifically a **linear function** (or **linear transformation**). \n\nA **linear transformation** is a
 function: $T : \\R^n \\rightarrow \\R^n$ that satisfies two properties for all vectors u, v and scalar c:\n\n1. **Additivity** $$T(u + v) = T(u) + T(v)$$\n2. **Homogeneity(scaling)**: $T(cu) = cT(u)$\n\n### The Bridge Between Matrix and Functions\nWhen
 we chose a **basis** for our vector spaces, any linear transformation _**T**_ can be represented by a **matrix** _A_ such tha
t: $T(x) = Ax$. So, while the matrix itself isn't the function, it's a representation of that function -- a concrete way to co
mpute the output. \n\n### Example: Matrix as Functions\nLet:\n$$\nA =\n\\begin{bmatrix}\n2 & 0 \\\\\n0 & 3\n\\end{bmatrix}\n$\n
\nDefine the function:\n$\nT(\\mathbf{x}) = A\\mathbf{x}\n$\n\nIf \n$\n\\mathbf{x} = \\begin{bmatrix} 1 \\\\ 2 \\end{bmatrix}\
n$\nthen:\n\n$$\nT(\\mathbf{x}) =\n\\begin{bmatrix}\n2 & 0 \\\\\n0 & 3\n\\end{bmatrix}\n\\begin{bmatrix}\n1 \\\\ 2\n\\end{bmatr
ix} = \n\\begin{bmatrix}\n2 \\\\ 6\n\\end{bmatrix}\n$\n\nSo here:\n- the **function** is \"scale _x_ by 2 and _y_ by 3\"\n- th
e **matrix** is its representation -- it encodes the same operation numerically\n\n### Why We Say \"A Matrix is a Function\"\n
When we say, \"the matrix transforms space\", we really mean the \"the **linear function** represented by this matrix transfor
ms space."

    content << [ "## Applying Mathematical Optimising Techniques in Python\n\n### Key Components\n1. **Gradient Descent**: This is
 a fundamental optimisation technique used to minimise loss functions in ML models. It iteratively adjusts model parameters to f
ind the minimum of a function. \n\n2. **Learning Rate**: This hyperparameter determines the step size at each iteration of the g
radient descent. Choosing an appropriate learning rate is crucial for convergence.\n\n3. **Loss Functions**: These are used to m
easure how well a model's predictions match the actual data. Common examples include _mean squared error_ and _cross-entropy_. \
n\n4. **Implementation in Python**: You can implement these concepts using libraries like _TensorFlow_ or _PyTorch_, which provi
de built-in functions for optimisation. ",
 "**Gradient Descent** is used to iteratively adjust model parameters to find the minimum of a loss function, ther
eby improving model accuracy.",
 "## AI/ML Landscape\nMachine Learning and Artifical Intelligence (AI/ML) are reshaping sectors such as healthcare
, transport and agriculture through data-driven decision-making and automation. At the same time, they introduce ethical conside
rations and challenges such as bias, a new way of working, data security and hallucinations in generative AI (GenAI).
",
 "## Linear Algebra\n\n**Vectors**\n- Represent _features_, predictions and model parameters\n- Operations\n  - **
Addition**: Vector addition combines two vectors by adding their corresponding components, resulting in a new vector.\n    - $a
+ b = (a_1 + b_1,\\cdots, a_n + b_n)$\n  - **Scalar multiplication**: Scalar multiplication scales a vector by a constant, chang
ing its magnitude but not its direction\n    - $k \\cdot v = (kv_1, \\cdots,k_n)$\n  - **Dot Product**: The dot product is calcu
lated by multiplying corresponding components of the vectors and summing the results.\n    - $a \\cdot b = \\sum a_ib_i$
1m",
 "## Linear Algebra\n**Matrices**\n\n**Conceptual summary of Matrices**\n  - A `2x2` matrix represents a linear tr
ansformation action on a **plane** ($\\R^2$). It describes how to **stretch**, **rotate**, or **shear** vectors in a 2D space. T
he plane is $\\R^2$ (the space of 2D vectors). The **matrix** is a function that transforms that space.\n\n  - A `3x3` matrix re
presents a linear transformation action on a 3D **space** ($\\R^3$). It can **rotate**, **scale**, **reflect**, or **shear** vec
tors in 3D. The space ($\\R^3$) contains surfaces. The **matrix** defines how to move or transform objects within that space.\n\
n**About**\n  - Used for representing data and transformations\n  - Matrix muplications: rows of `A` and columns of `B`. **Matri
x multiplication** is performed by taking the **dot product** of the rows of the first matrix(`A`) with the columns of the secon
d matrix(`B`)\n  - **identity matrix**: _**I**_. The **identity matrix** is  a special matrix that, when multiplies with another
 matrix or vector, leaves it unchanged. \n  - zero matrix: `0`. A **zero matrix** is a matrix in which all the elements are zero
, and it represents a transformation that maps all vectors to the _zero vector_.\n",
 "## Matrices and Functions - The Connection\n\nIn **linear algebra**, a matrix is one way to represent a specific
 kind of function -- specifically a **linear function** (or **linear transformation**). \n\nA **linear transformation** is a fun
ction: $T : \\R^n \\rightarrow \\R^n$ that satisfies two properties for all vectors u, v and scalar c:\n\n1. **Additivity**: $T(
u + v) = T(u) + T(v)$\n2. **Homogeneity(scaling)**: $T(cu) = cT(u)$\n\n### The Bridge Between Matrix and Functions\nWhen we chos
e a **basis** for our vector spaces, any linear transformation _**T**_ can be represented by a **matrix** _A_ such that: $T(x) =
 Ax$. So, while the matrix itself isn't the function, it's a representation of that function -- a concrete way to compute the ou
tput. \n\n### Example: Matrix as Functions\nLet:\n$\nA =\n\\begin{bmatrix}\n2 & 0 \\\\\n0 & 3\n\\end{bmatrix}\n$\n\nDefine the f
unction:\n$\nT(\\mathbf{x}) = A\\mathbf{x}\n$\n\nIf \n$\n\\mathbf{x} = \\begin{bmatrix} 1 \\\\ 2 \\end{bmatrix}\n$\nthen:\n\n$\n
T(\\mathbf{x}) =\n\\begin{bmatrix}\n2 & 0 \\\\\n0 & 3\n\\end{bmatrix}\n\\begin{bmatrix}\n1 \\\\ 2\n\\end{bmatrix} = \n\\begin{bm
atrix}\n2 \\\\ 6\n\\end{bmatrix}\n$\n\nSo here:\n- the **function** is \"scale _x_ by 2 and _y_ by 3\"\n- the **matrix** is its
representation -- it encodes the same operation numerically\n\n### Why We Say \"A Matrix is a Function\"\nWhen we say, \"the mat
rix transforms space\", we really mean the \"the **linear function** represented by this matrix transforms space.",
 "## Eigenvalue and Eigenvectors\nEigenvalues and Eigenvectors are fundamental in both **Linear Algebra** and **Ma
chine Learning**, especially in areas like **dimensionality reduction**, **Principle Component Analysis (PCA)*, and understandin
g **Linear Transformations**. A **matrix** can represent a **linear transformation**. Most vectors _change direction_ when a mat
rix acts on them. However, a few special vectors don't -- they only get _stretched_ or _shrunk_, not **_rotated_**.\n\nThese spe
cial vectors are called **eigenvectors**, and the factor by which they are stretched or shrunk is the **eigenvalue**.\n\n- $Av =
 \\lambda v$\n- used in *Principle Component Analysis*, data compression and stability analysis",
 "## Eigenvalue and Eigenvectors in ML\n\n| Concept | Meaning | in ML|\n|:---|:---|:---|\n|Eigenvector | Direction
 that doesn't rotate under a transformation | Principle Component direction\n|Eigenvalue| Factor by which it's stretched/shrunk|
 Amount of variance or importance |\n|Characteristic equation| $det(A - \\lambda I) = 0$| used to find eigenvalues |\n|Covarianc
e matrix | Measures spread of data | PCA computes its eigenvectors|",
 "### Matrix Norms\n\nIn Machine Learning context, **norms** measure _vector magnitude_ and are used in **regulari
sation**, _distance metrics_, and **gradient clipping**. **Regularisation** is when you have a dataset that your model is traine
d on. It prevents from overfitting.",
 "A **Norm** is a function $ \\| \\cdot \\|$ that maps a vector $\\mathbf{x} \\in \\mathbb{R}^n$  to a non-negativ
e number, satisfying:\n\n1. **Non-negativity**:\n$\\|\\mathbf{x}\\| \\ge 0, \\quad \\text{and } \\|\\mathbf{x}\\| = 0 \\text{ on
ly if } \\mathbf{x} = 0 $\n\n2. **Scaling (Homogeneity)**: \n$\\|\\alpha \\mathbf{x}\\| = |\\alpha| \\, \\|\\mathbf{x}\\|$\n\n3.
 **Triangle Inequality**:\n$\\|\\mathbf{x} + \\mathbf{y}\\| \\le \\|\\mathbf{x}\\| + \\|\\mathbf{y}\\|$\n\n### Norms in ML\nIn M
achine Learning, **norms** are used to:\n1. **Regularise models** (control complexity):\n  - L1 and L2 regularisation penalise l
arge weights using norms.\n  - Example: $ \\text{Loss} = \\text{MSE} + \\lambda \\|\\mathbf{w}\\|_2^2$\n\n2. **Measure Distances
**:\n  - Between data points (e.g. Euclidean distance in k-NN)\n  - Between predicted and actual values (error norms)\n\n3. **No
rmalise data/gradients**:\n  - Ensures stable training by keeping vectors at controlled magnitudes.\n\n## Intuitive Example\nSup
pose you have a vector $\\mathbf{x} = [3, 4]$\n\n  - $\\|\\mathbf{x}\\|_1 = 3 + 4 = 7$\n  - $\\|\\mathbf{x}\\|_2 = \\sqrt{3^2 +
4^2} = 5$\n  - $\\|\\mathbf{x}\\|_\\infty = \\max(3, 4) = 4$\n\nSo the L2 norm corresponds to the usual length of the vector in
2D space.",
 "## React Context\n Passing props is a mechanism for explicitly passing data through UI trees to the components t
hat need to use it. React **context** allows to _teleport_ data to the components in the tree that need it without passing props
. **Context** is an alternative to passing props. It allows a parent component to provide data to the entire tree below it. This
 allows a child component to \"ask\" for data from somewhere above in the tree. \n\n> Context lets a parent -- even a distant on
e! -- provide some data to the entire tree inside of it.",
 "**Regression** is a statistical technique that relates a dependent variable to one or more independent variables
. Regression analysis is used to understand the relationship between a dependent variable and one or more independent variables.
 A regression model shows whether changes observed in the dependent variable are associated with changes in one or more of the i
ndependent variables.",
 "## Machine Learning\n### What is Machine Learning?\nAt its core, **machine learning** is about finding a functio
n that maps input variables (features) to output variables (targets). Machine learning focuses on learning a function that maps
input features to output targets, enabling predictions or decisions based on new data.\n$$\nf : X \\rightarrow Y\n$$\n\nWhere:\n
- $X$ represents input features (e.g. house size, location, age)\n- $Y$ represents output/target (e.g. house price)\n- $f$ is th
e function we're trying to learn\n\n**Example**: Predicting house prices\n- **Input**: square footage, number of bedrooms, locat
ion\n- **Output**: price\n - **Goal**: Learn the function, $f$ that best maps inputs to outputs\n\nthat best maps inputs to outp
uts",
 "## Machine Learning\n### Types of Variables\nUnderstanding variable types is crucial for choosing appropriate ML
 algorithms.\n\n#### Numeric Variables\n- **Continuous**: Can take any value within a range (e.g. termperature, height, price)\n
- **Discrete**: Countable values (e.g., number of children, items sold)\n\n#### Categorical Variables\n1. **Binary**: only two p
ossible values\n    - Example: _Yes_/_No_\n2. **Ordinal**: Categories with a meaningful order\n   - Example: Education level (Hi
gh school < Batchelor;s < Master's < PhD)\n3. **Nominal**: Categories without inherent order\n   - Example: Color (Red. Blue,, G
reen)\n   - Example: Country ( Ghana, Nigeria, England)",
 "## Machine Learning\n### Forecasting vs. Inference\n#### Forecasting (Prediction)\n- **Goal**: accurately predic
t future or unseen outcomes\n- **Focus**: prediction accuracy\n- **Example**: prediction tomorrow's stock price\n- **Don't care
much about:**: Why the model works, just that it works\n\n#### Inference\n- **Goal**: understand relationships between variables
\n- **Focus**: interpretability and causality\n- **Example**: undersatanding how education affects income\n- **Care about**: whi
ch features matter, how they relate, statistical significance\n\n|Aspect|Forecasting|Inference|\n|:---|:---|:---|\n|**Primary Go
al**| Accurate predictions| understanding relationships|\n|**Model Complexity**|can be a \"black box\"|Prefer interpretable mode
ls|\n|**Feature Selection**|use what improves accuracy|Use what has meaning|\n|**Example Question**|\"what will happen?\"|\"why
does it happen?\"|" ]

    # 1.upto(5) do
    #   content << Faker::Lorem.paragraph(sentence_count: [ *30..45 ].sample)
    #   content << Faker::Markdown.block_code
    #   content << Faker::Markdown.emphasis
    # end
    content << "Hello **World**"
    content << "$$ F(x) = x^2 + 1 $$"
    content << "Text with $E = mc^2$ inside a sentence."
    content.flatten
  end
end
