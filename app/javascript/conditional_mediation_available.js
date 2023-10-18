class ConditionalMediationNotSupportedError extends Error {
  constructor(message) {
    super(message)
    this.name = "ConditionalMediationNotSupportedError"
  }
}

let conditionalMediationAvailable = async function(){
  if (
    typeof window.PublicKeyCredential !== 'undefined'
    && typeof window.PublicKeyCredential.isConditionalMediationAvailable === 'function'
  ) {
    return await PublicKeyCredential.isConditionalMediationAvailable()
  } else {
    return Promise.reject(new ConditionalMediationNotSupportedError('Browser does not support Conditional Mediation'))
  }
}


export {conditionalMediationAvailable, ConditionalMediationNotSupportedError}