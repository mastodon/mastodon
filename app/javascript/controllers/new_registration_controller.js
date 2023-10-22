import { Controller } from "@hotwired/stimulus"
import * as Credential from "credential";

export default class extends Controller {
  connect() {
    console.log("new-registration connect");
  }
  
  submit(event) {
    console.log("new-registration click", event);
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
        // console.log("new-registration data", data);
        // const { callback_url, create_options } = data;
        // console.log("new-registration callback_url", callback_url);
        // console.log("new-registration create_options", create_options);
        
        // if (create_options["user"]) {
          // const xxx = encodeURI(callback_url);
          // console.log("new-registration xxx", xxx)
          // Credential.create(xxx, create_options);
        if (data.create_options.user) {
          Credential.create(data);
        }                       // else ????
      });
    }
    
    function err(response) {

      console.log("new-registration Error", response);
    }
  }
}

