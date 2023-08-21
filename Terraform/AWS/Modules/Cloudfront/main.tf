resource "aws_budgets_budget" "budgets_cost" {
  name        = var.name                          #"mi_presupuesto"
  budget_type = var.budget_type                   #"COST" or "USAGE"
  limit_amount = var.limit_amount                 #"1000"
  limit_unit = var.limit_unit                     #"USD"
  time_unit = var.time_unit                       #[MONTHLY, QUARTERLY, ANNUALLY, and DAILY]
  #time_period_start = "2022-01-01T00:00:00Z"     #(Opcional)Format: 2017-01-01_12:00

  notification {
      comparison_operator        = "GREATER_THAN"                      #(Required) Operador de comparación [LESS_THAN "<", EQUAL_TO "=" o GREATER_THAN">"]
      threshold                  = "100"                               #(Required) Umbral cuando se debe enviar la notificación.
      threshold_type             = "PERCENTAGE"                        #(Required) PERCENTAGE, ABSOLUTE_VALUE
      notification_type          = "ACTUAL"                            #(Required) ACTUAL or FORECASTED
      subscriber_email_addresses = var.subscriber_email_addresses      #["test@example.com"] # Max 10 Emails
      subscriber_sns_topic_arns  = [var.subscriber_sns_topic_arns]
    }

  notification {
      comparison_operator        = "GREATER_THAN"
      threshold                  = "80"
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.subscriber_email_addresses
      subscriber_sns_topic_arns  = [var.subscriber_sns_topic_arns]
    }
}