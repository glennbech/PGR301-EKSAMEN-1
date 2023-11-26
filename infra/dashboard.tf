resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.candidate_number
  dashboard_body = <<DASHBOARD
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${var.candidate_number}",
            "violations.value"
          ]
        ],
        "period": 300,
        "stat": "Maximum",
        "region": "eu-west-1",
        "title": "Total number of Violations"
      }
    },
    /*
    
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${var.candidate_number}",
            "number_checked.value"
          ]
        ],
        "period": 300,
        "stat": "Maximum",
        "region": "eu-west-1",
        "title": "Total number of persons checked"
      }
    }*/
  ]
}
DASHBOARD
}