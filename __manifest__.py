{
    'name': 'Antbook BI Dashboard',
    'version': '1.0',
    'author': 'Antbook Team',
    'depends': ['base', 'web', 'sale'],
    'data': [
        'security/security.xml',
        'security/ir.model.access.csv',
        'views/antbook_menu.xml',
        'views/order_view.xml',
        'views/sales_dashboard.xml',
        'views/assets.xml'
    ],
    'assets': {
        'web.assets_backend': [
            'antbook_bi/static/src/js/dashboard.js',
            'antbook_bi/static/src/css/dashboard.css',
        ],
    },
    'installable': True,
    'application': True,
}
