import { LightningElement, api } from 'lwc';
import {
	FlowAttributeChangeEvent,
	FlowNavigationBackEvent,
	FlowNavigationNextEvent
} from "lightning/flowSupport";

export default class ApplicationStepNavigation extends LightningElement {
  @api availableActions = [];
  @api enableButtons;
  @api nextButtonLabel;
  @api backButtonLabel;
  @api pageStepNumber;
  @api disableNextButton;

  connectedCallback() {
  	if(this.nextButtonLabel == null) this.nextButtonLabel = 'NEXT STEP';
	if(this.backButtonLabel == null) this.backButtonLabel = 'LAST STEP';

	if(this.enableButtons == 'Both') {
		this.showNext = true;
		this.showBack = true;
	}
	else if(this.enableButtons == 'None') {
		this.showNext = false;
		this.showBack = false;
	}
	else if(this.enableButtons == 'Next') {
		this.showNext = true;
		this.showBack = false;
	}
	else {
		this.showNext = false;
		this.showBack = true;
	}
  }

  handleNext() {
    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }

  handleBack() {
    if (this.availableActions.find((action) => action === "BACK")) {
      const navigateBackEvent = new FlowNavigationBackEvent();
      this.dispatchEvent(navigateBackEvent);
    }
  }
}