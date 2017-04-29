node(:event) { 'delete' }
node(:payload) { |event| event.payload.id }
