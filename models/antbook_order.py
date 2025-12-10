from odoo import models, fields

class AntbookOrder(models.Model):
    _name = 'antbook.order'
    _description = 'Antbook Sales Order'

    customer_name = fields.Char(string='Customer Name', required=True)
    book_title = fields.Char(string='Book Title', required=True)
    category = fields.Selection([
        ('fiction', 'Fiction'),
        ('nonfiction', 'Non Fiction'),
        ('education', 'Education'),
        ('kids', 'Kids')
    ])
    quantity = fields.Integer(string='Quantity')
    price = fields.Float(string='Price')
    date_order = fields.Date(string='Order Date', default=fields.Date.today())
