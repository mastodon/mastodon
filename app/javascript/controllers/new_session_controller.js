import { Controller } from "@hotwired/stimulus"
import * as Credential from "credential";

export default class extends Controller {
  connect() {
    console.log("new-session connect");
  }
  
  submit(event) {
    console.log("new-session click", event);
    event.preventDefault();
    
    const headers = new Headers();
    const action = event.target.action;
    const options = {
      method: event.target.method,
      headers: headers,
      body: new FormData(event.target)
    };
    
    fetch(action, options).then((response) => {
      if (response.ok) {
        ok(response);
      } else {
        err(response);
      }
    });
    
    function ok(response) {
      response.json().then((data) => {
        console.log("new-session#ok: data", data)
        Credential.get(data);
      });
    }
    
    function err(response) {
      console.log("new-session Error", response);
      response.json().then((json) => {
        const message = response.statusText + " - " + json.errors.join(" ");
        console.log("new-session text", message)
        Credential.displayError(message);
      });
    }
  }
}

