def seed_collection
  puts "Seeding Collection Data..."
  delete_existing_collections
  puts "Successfully seeded Collection Data!"

  user = User.find_or_create_by(email: "mightyj@hotmail.co.uk")
  user.collections.create(label: Collection::DEFAULT_CATEGORY_LABEL, public: true)

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

  parent = Collection.create(user:, label: "Mathematics", parent_id: nil, position: 0, public: true)
  Note.create(user:, collection_id: parent.id, raw_content: "Gaussian Theorem is fun", public: true)
  Collection.create(user:, label: "Linear Algebra", parent:, position: 0, public: true)

  parent = Collection.create(user:, label: "Computer Science", parent_id: nil, position: 0, public: true)
  Collection.create(user:, label: "Quantum Computing", parent:, position: 0, public: true)
  Collection.create(user:, label: "Advanced Programming", parent:, position: 1, public: true)

  parent = Collection.create(user:, label: "History", parent_id: nil, position: 0, public: true)
    Collection.create(user:, label: "Modern Warfare", parent:, position: 1, public: true)
    Collection.create(user:, label: "Ancient Battles", parent:, position: 2, public: true)
    parent = Collection.create(user:, label: "Historical Figures", parent:, position: 3, public: true)
      parent = Collection.create(user:, label: "Jesus Christ", parent:, position: 4, public: true)
        parent = Collection.create(user:, label: "Gospel", parent:, position: 0, public: true)
        parent = Collection.create(user:, label: "Post-Apocalyptic", parent:, position: 0, public: true)

  notes_data.each do |note_data|
    Note.create(
      user:,
      collection_id: Collection.all.map(&:id).sample,
      raw_content: note_data[:raw_content],
      public: [ true, false ].sample
    )
  end
end

def delete_existing_collections
  Reminder.delete_all
  Note.delete_all
  Collection.delete_all
end
