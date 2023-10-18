import {
  get,
  parseRequestOptionsFromJSON,
} from "@github/webauthn-json/browser-ponyfill";

let getReauthenticationToken = async function(form){
  const csrfToken = document.getElementsByName("csrf-token")[0].content;
  let reauthenticationTokenFieldName = form.dataset.reauthenticationTokenFieldName
  let reauthenticationChallengeURL = new URL(form.dataset.reauthenticationChallengeUrl)
  let reauthenticationTokenURL = new URL(form.dataset.reauthenticationTokenUrl)

  let challengeFetch = fetch(reauthenticationChallengeURL, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "X-CSRF-Token": csrfToken,
    },
  })

  const challengeJSON = await(await challengeFetch).json()
  const credentialAuthenticationOptions = parseRequestOptionsFromJSON({publicKey: challengeJSON})

  const credentialAuthenticationResponse = await get(credentialAuthenticationOptions)

  let reauthenticationTokenFetchBody = {
    passkey_credential: JSON.stringify(credentialAuthenticationResponse)
  }

  let reauthenticationTokenFetch = fetch(reauthenticationTokenURL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": csrfToken,
    },
    body: JSON.stringify(reauthenticationTokenFetchBody)
  })

  const reauthenticationTokenResponse = await(await reauthenticationTokenFetch).json()

  form.elements[reauthenticationTokenFieldName].value = reauthenticationTokenResponse.reauthentication_token
}


export {getReauthenticationToken}