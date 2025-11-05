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
    content << "This is inline math: \(x^2 + x + 1 = 0\). This equation is often called the golden equation."
    content << "The equation \$E=mc^2\$ is famous"
    content << "This sentence uses $\` and \`$ delimiters to show math inline: $`\sqrt{3x-1}+(1+x)^2`$"
    content << "Formula
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
$$."
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

    # 1.upto(5) do
    #   content << Faker::Lorem.paragraph(sentence_count: [ *30..45 ].sample)
    #   content << Faker::Markdown.block_code
    #   content << Faker::Markdown.emphasis
    # end
    content << "Hello **World**"
    content << "$$ F(x) = x^2 + 1 $$"
    content << "Text with $E = mc^2$ inside a sentence."
  end
end
