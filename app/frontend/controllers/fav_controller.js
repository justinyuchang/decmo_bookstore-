
import { Controller } from "stimulus"
import ax from 'helpers/ax'; 

export default class extends Controller {
  static targets = [ "icon" ]

  connect() {
    console.log('hi');
  }
  toggle(evt) {
    evt.preventDefault();
    
    let id = this.data.get('id');
    let icon = this.iconTarget; 
    let button = evt.currentTarget; 

    button.classList.add('is-loading');

    ax.post(`/api/books/${id}/favorite`, {})
      .then(function(response) {
        let favorited = response.data.favorited;

        if (favorited) {
          icon.classList.remove('far');
          icon.classList.add('fas');
        } else {
          icon.classList.remove('fas');
          icon.classList.add('far');
        }
      })
      .catch(function(error){
        if (error.response.status === 401) {
          alert('Require to login.');
        } else {
          alert('Error occurs, try try see later.');
        }
      })
      .finally(function(){
        button.classList.remove('is-loading');
      });
  }
}
