object @app
attributes :id, :redirect_uri
node(:client_id) { |app| app.uid }
node(:client_secret) { |app| app.secret }
