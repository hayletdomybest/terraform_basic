output "cluster" {
    value = aws_ecs_cluster.cluster
}

output "task_definition" {
    value = aws_ecs_task_definition.task_definition
}