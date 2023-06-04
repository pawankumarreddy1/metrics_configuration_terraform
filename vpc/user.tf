resource "aws_iam_user" "prometheus-sd-user" {
  name = "prometheus-sd-user"
  path = "/"
}

resource "aws_iam_user_policy_attachment" "prometheus-sd-user-ec2-ro" {
  user = aws_iam_user.prometheus-sd-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}