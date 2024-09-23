output "lambda_name" {
  description = "Name of the generated Lambda function"
  value       = aws_lambda_function.book_better_bot.function_name
}
