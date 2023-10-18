import {
  get,
  parseRequestOptionsFromJSON,
} from "@github/webauthn-json/browser-ponyfill";

import {conditionalMediationAvailable} from "conditional_mediation_available"


let startConditionalMediation = async function(form){
  const available = await conditionalMediationAvailable()
  if(!available){ return }

  getChallengeAndSubmitCredential(form)
}

let getChallengeAndSubmitCredential = async function(form){
  const csrfToken = document.getElementsByName("csrf-token")[0].content;
  let credentialFieldName = form.dataset.credentialFieldName
  let newChallengeURL = new URL(form.dataset.challengeUrl)

  let challengeFetch = fetch(newChallengeURL, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "X-CSRF-Token": csrfToken,
    },
  })

  const challengeJSON = await(await challengeFetch).json()
  const credentialAuthenticationOptions = parseRequestOptionsFromJSON({publicKey: challengeJSON})

  const credentialAuthenticationResponse = await get(credentialAuthenticationOptions)

  form.elements[credentialFieldName].value = JSON.stringify(credentialAuthenticationResponse)
  form.submit()
}

let submitFormEvent = async function(event){
  event.preventDefault()
  event.stopImmediatePropagation()
  let form = event.currentTarget
  getChallengeAndSubmitCredential(form)
}


export {startConditionalMediation, submitFormEvent}