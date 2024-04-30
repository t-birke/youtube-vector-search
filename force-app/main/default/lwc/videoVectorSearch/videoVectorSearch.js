import { LightningElement } from 'lwc';
import query from '@salesforce/apex/VideoSearchController.query';

export default class VideoVectorSearch extends LightningElement {
	response;
    results;
	error;
    searchTerm = '';

    decode(s){
        let decodedString = s.replace(/&#39;/g, '\''); 
        decodedString = decodedString.replace(/&gt;/g, '>'); 
        return decodedString;
    }

    removeTimeStamps(text){
        const globalPattern = /\[\d+\]>/g; // Global regex for removing all occurrences
        // Removing all occurrences of the pattern from the text
        return text.replace(globalPattern, ' ');
    }

    getStartTime(text) {
        // Regex to find the pattern, capturing digits between the brackets
        const pattern = /\[(\d+)\]>/;
        // Extracting the first integer
        const firstMatch = text.match(pattern);
        let number = null;
        if (firstMatch && firstMatch[1]) {
            number = parseInt(firstMatch[1], 10);  // Convert captured string to an integer
        }
        //reverse 30 seconds 
        number-= 30;
        return number;
    }

    formatPercentage(value) {
        // Convert the float to a percentage and format it with one decimal place
        let percentage = (value * 100).toFixed(1);
        // Append the percentage sign
        return percentage + '%';
    }
    

    parseResult(data){
        const result = [];
        let i = 1;
        data.forEach(e => {
            let chunk = this.decode(e[1]);
            let row = {
                "rank":i,
                "video_id_c__c":e[2],
                "Score__c":e[0],
                "scoreInPercent":this.formatPercentage(e[0]),
                "Chunk__c":chunk,
                "embedSource":"https://www.youtube.com/embed/" + e[2] + "?start=" + this.getStartTime(chunk)
            }
            row.Chunk__c = this.removeTimeStamps(row.Chunk__c);
            result.push(row)
            i++;
        });
        return result;
    }

    handleSearchChange(event) {

        this.searchTerm = event.target.value;
    }

	handleButtonClick(event){
		const searchKey = this.searchTerm;//"how do I create a lightning web component that returns Data Cloud Data and displays it in my home org?";//event.target.value;
        console.log("button KLIKK")
		query({ query: searchKey })
		.then(result => {
			this.response = result;
            this.results = this.parseResult(this.response.data);
			this.error = undefined;
		})
		.catch(error => {
			this.error = JSON.stringify(error);
            console.log("error: " + this.error);
			this.response = undefined;
		})
	}
}