addEventListener("load", (event) => {
    const ref = document.querySelector("#accept-rules-btn")
    if (ref) { //!ref should not happen but just being defensive
        ref.click()
    }
});