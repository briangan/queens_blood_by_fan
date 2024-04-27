// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

const findOverflows = () => {
  const documentWidth = document.documentElement.offsetWidth;

  document.querySelectorAll('.board-spot').forEach(element => {
      const box = element.getBoundingClientRect();

      if (box.left < 0 || box.right > documentWidth) {
          console.log(element);
          element.style.border = '1px solid red';
      }
  });
};

// Execute findOverflows to find overflows on the page.
findOverflows();