from odoo import models, fields

class SalesPrediction(models.Model):
    _name = 'antbook.sales.prediction'
    _description = 'Antbook Sales Prediction'

    predicted_date = fields.Date(string='Predicted Date')
    predicted_sales = fields.Float(string='Predicted Sales')
    model_version = fields.Char(string='Model Version', default="v1.0")
