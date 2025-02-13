import {LightningElement, api} from "lwc";
import sendFaxAction from "@salesforce/apex/FaxController.sendFaxAction";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class SendFaxForm extends LightningElement {
    
   @api recordId;
   handleSendFaxClick(event) {
       let button = event.target;
       button.disabled = true;
       sendFaxAction({leadId: this.recordId})
           .then(() => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Success",
                       message: "Fax has been added to queue",
                       variant: "success"
                   })
               );
               button.disabled = false;
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error while sending fax",
                       message: error,
                       variant: "error"
                   })
               );
               button.disabled = false;
           });
   }
}