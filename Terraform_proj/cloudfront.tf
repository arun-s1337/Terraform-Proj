resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "EKS-LoadBalancer"
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "CloudFront for EKS App"
}
