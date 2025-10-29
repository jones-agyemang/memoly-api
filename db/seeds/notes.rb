DEFAULT_SEVERITY = Logger::Severity::WARN
Rails.logger.log(DEFAULT_SEVERITY, 'Clearing existing data...')
Note.destroy_all
Rails.logger.log(DEFAULT_SEVERITY, 'Existing data cleared.')

notes_data = [
  {
    topic: "Advanced Ruby",
    raw_content: "In advanced Ruby, mastering metaprogramming is crucial. Techniques like `define_method`, `method_missing`, and `class_eval` allow developers to write flexible and dynamic code. Understanding Ruby's object model, especially singleton classes, empowers you to manipulate behavior at runtime. Additionally, knowing when to use Procs, Lambdas, and Blocks effectively can lead to cleaner APIs. Careful use of these features ensures powerful DSL creation without compromising code maintainability.",
    source: "https://www.rubydoc.info/"
  },
  {
    topic: "Advanced Ruby",
    raw_content: "Exploring Ruby refinements provides a safer alternative to monkey patching by allowing scoped modifications to existing classes. This prevents global side effects while still enabling elegant syntax improvements within specific contexts. Combined with `Enumerable` and lazy evaluation, Ruby offers powerful tools for handling large data sets efficiently. Understanding garbage collection tuning is also key for optimizing performance in memory-intensive applications.",
    source: "https://www.rubydoc.info/"
  },
  {
    topic: "Rails Best Practices",
    raw_content: "To maintain a scalable Rails application, developers should adopt patterns like Service Objects, Decorators, and Form Objects. These patterns help extract business logic from controllers and models, avoiding the infamous 'fat model, fat controller' scenario. Additionally, leveraging `ActiveSupport::Concern` promotes reusable, modular code. Consistent use of scopes, validations, and callbacks ensures clean and predictable data interactions throughout the application lifecycle.",
    source: "https://guides.rubyonrails.org/"
  },
  {
    topic: "Rails Best Practices",
    raw_content: "Effective Rails development emphasizes RESTful design, background job delegation, and caching strategies. Utilizing `fragment caching` with Redis or Memcached can drastically improve performance. Developers should also apply database indexing wisely to optimize query speed. Testing with RSpec and maintaining CI pipelines ensures code quality, while tools like Brakeman help identify security vulnerabilities early in the development process.",
    source: "https://guides.rubyonrails.org/"
  },
  {
    topic: "Redis Patterns",
    raw_content: "Redis is more than just a key-value store; it offers advanced data structures like Lists, Sets, and Sorted Sets. Implementing caching strategies with expiration (`TTL`) can prevent stale data and reduce database load. Redis Pub/Sub enables lightweight messaging systems, ideal for real-time features. It’s important to monitor memory usage and apply eviction policies to handle high-traffic scenarios gracefully.",
    source: "https://redis.io/docs/"
  },
  {
    topic: "Redis Patterns",
    raw_content: "Using Redis for rate limiting is a common pattern in API development. By leveraging atomic operations like `INCR` and setting expirations, developers can effectively control request bursts. Additionally, Redis Streams provide a powerful tool for handling event-driven architectures, allowing persistent and scalable message queues without the overhead of traditional brokers.",
    source: "https://redis.io/docs/"
  },
  {
    topic: "Sidekiq Job Management",
    raw_content: "Sidekiq excels at handling background jobs efficiently using multithreading. Best practices include keeping jobs idempotent, passing only lightweight arguments (like IDs), and setting retry limits to avoid infinite loops. Monitoring the Web UI for dead jobs and queue latency is critical in production. For recurring tasks, integrating `sidekiq-scheduler` or `cron` extensions ensures automated job execution at defined intervals.",
    source: "https://sidekiq.org/"
  },
  {
    topic: "Sidekiq Job Management",
    raw_content: "Optimizing Sidekiq involves fine-tuning concurrency settings and isolating critical jobs into separate queues. This prioritization ensures time-sensitive tasks aren't delayed by bulk processing jobs. Implement middleware for logging, error tracking, and performance metrics to gain deeper insights into job behavior. Leveraging Redis' reliability, Sidekiq scales horizontally with ease, making it suitable for high-demand applications.",
    source: "https://sidekiq.org/"
  },
  {
    topic: "TypeScript Tips",
    raw_content: "TypeScript enhances JavaScript by adding static typing, which helps catch errors early during development. Utilizing utility types like `Partial`, `Pick`, and `Record` can greatly simplify complex type transformations. Embracing strict mode ensures safer code, while interfaces and type aliases promote clear API contracts. Generics offer reusable components and functions, making large codebases easier to maintain and scale.",
    source: "https://www.typescriptlang.org/docs/"
  },
  {
    topic: "TypeScript Tips",
    raw_content: "Advanced TypeScript techniques include discriminated unions for handling complex state management scenarios. Type Guards help in narrowing types safely at runtime, while mapped types allow developers to dynamically transform existing types. Integrating TypeScript with React or Node.js projects improves developer experience and reduces runtime bugs through clear, enforced type definitions.",
    source: "https://www.typescriptlang.org/docs/"
  },
  {
    topic: "Kubernetes Deployment",
    raw_content: "Successful Kubernetes deployments require defining clear resource requests and limits to ensure fair scheduling. Implementing liveness and readiness probes guarantees that only healthy pods receive traffic. Use ConfigMaps and Secrets to manage environment configurations securely. Namespace isolation, combined with Role-Based Access Control (RBAC), enhances security posture in multi-team environments.",
    source: "https://kubernetes.io/docs/"
  },
  {
    topic: "Kubernetes Deployment",
    raw_content: "Automating deployments with CI/CD pipelines integrated into Kubernetes via tools like ArgoCD or Flux streamlines operational workflows. Horizontal Pod Autoscaling adjusts workloads based on CPU or custom metrics, ensuring efficient resource utilization. It's also critical to implement network policies and monitor cluster health using Prometheus and Grafana for observability.",
    source: "https://kubernetes.io/docs/"
  },
  {
    topic: "Helm Chart Strategies",
    raw_content: "Helm simplifies Kubernetes application deployment by templating manifests. Structuring charts with reusable templates and leveraging `values.yaml` files promotes DRY principles. For multi-environment deployments, maintain separate values files to handle configuration differences cleanly. Helm hooks offer lifecycle automation, while Helmfile can manage multiple charts in a single deployment process.",
    source: "https://helm.sh/docs/"
  },
  {
    topic: "Helm Chart Strategies",
    raw_content: "Versioning Helm charts correctly is essential for reliable rollbacks and upgrades. Use semantic versioning and document changes clearly in Chart.yaml. Secure Helm deployments by avoiding hardcoded secrets and integrating with external secret managers. Validating templates locally before pushing to production reduces misconfiguration risks significantly.",
    source: "https://helm.sh/docs/"
  }
]

# Create Notes (your existing notes_data logic)
while notes_data.size < 25
  notes_data << notes_data.sample.merge(raw_content: notes_data.sample[:raw_content] + " This note expands on previous learnings with practical examples.")
end

notes = notes_data.shuffle.map do |note_data|
  Note.create!(
    raw_content: note_data[:raw_content],
    source: note_data[:source]
  )
end

Rails.logger.log(DEFAULT_SEVERITY, 'Notes and auto-generated reminders created. Updating reminders...')

processed_notes = []

# 1️⃣ 5 notes ➜ All reminders completed
all_completed_notes = notes.sample(5)
all_completed_notes.each do |note|
  note.reminders.update_all(completed: true)
end
processed_notes += all_completed_notes

# 2️⃣ 4 notes ➜ All but one reminder completed
remaining_notes = notes - processed_notes
almost_all_completed_notes = remaining_notes.sample(4)

almost_all_completed_notes.each do |note|
  total_reminders = note.reminders.count
  note.reminders.limit(total_reminders - 1).update_all(completed: true)
  note.reminders.order(:id).last.update(completed: false)
end
processed_notes += almost_all_completed_notes

Note.joins(:reminders)
    .select { |note| note.reminders.where(completed: true).count < 5 }
    .sample(7)
    .each { |note| note.reminders.limit(3).update_all(completed: true) }

Rails.logger.log(DEFAULT_SEVERITY, "Processed #{processed_notes.size} notes across categories.")
