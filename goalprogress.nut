/*
	Simpleton City Builder goalprogress.nut
*/

//get best company from companies that have better score than goal or best when score=0
function SimpletonCB::BestCompany(score = 0){
	local winner = 255;
	local tmp;
	foreach(town in this.townlistCB){
		tmp = GSTown.GetPopulation(town.id);
		if(tmp > score){
			score = max(tmp, score);
			winner = town.owner;
		}
	}
	return [winner, score];
}

function SimpletonCB::GoalProgress(checkgamelength = 0){
	if(this.goalstatus == 1) {
		return;
	}

	local gameTimeEnd = this.game_length > 0 && checkgamelength >= this.game_length;
	if(this.goal > 0 || gameTimeEnd){ //when goal or time limit was reached
		local winQ = BestCompany();
		local winner = winQ[0];
		local winamount = winQ[1];

		if(winamount >= this.goal || gameTimeEnd){ //somebody won or time up
			this.goalstatus = 1;
			//if(GSGame.IsMultiplayer()) GSGame.Pause(); //pause only multiplayer, in single player it would be impossible to unpause
			local txt;
			if(checkgamelength >= this.game_length) {
				txt = GSText.STR_WINNER_TIME;
			}
			else {
				txt = GSText.STR_WINNER_GOAL;
			}
			this.SendGlobalMessage(GSText(txt, winner, winamount));
			this.adminbot.SendGSLog( "SMCB:END" )
		}
	}
}

function SimpletonCB::SendGlobalMessage(txt){
	foreach(company in this.companies){
		GSGoal.Question(0, company.id, txt, GSGoal.QT_INFORMATION, GSGoal.BUTTON_CLOSE);
	}
}

/* story page */
//functio to prepare story page on script start/load
function SimpletonCB::StoryStart(){
	//always remove cargo requirements page when starting or form save
	if(GSStoryPage.IsValidStoryPage(1)) {
		GSStoryPage.Remove(1);
	}

	//only add goal progress page when there is none
	if(!GSStoryPage.IsValidStoryPage(0)) {
		this.story.append(GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_STORY_TITLE))); //id0, yearly progress
	}
	//if exists, just add to internal list
	else {
		this.story.append(0);
		local elemList = GSStoryPageElementList(0);
		foreach(elemid, _ in elemList) {
			this.storyElement.append(elemid);
		}
	}

	this.story.append(GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_STORY_TITLE_REQ))); //id 1, cargo requirements

	GSStoryPage.NewElement(
		this.story[1],
		GSStoryPage.SPET_TEXT,
		0,
		GSText(GSText.STR_TOWN_CLAIMED_RES)
	);

	foreach(cargo in this.CBcargo){
		GSStoryPage.NewElement(
			this.story[1],
			GSStoryPage.SPET_TEXT,
			0,
			GSText(GSText.STR_TOWN_CLAIMED_CARGOS, cargo.req, 1 << cargo.id, cargo.from, cargo.store)
		);
	}
}
//feed yearly progress
function SimpletonCB::Story(){
	local leader = BestCompany();
	local companyid = leader[0];
	local score = leader[1];
	
	if(companyid == 255) {
		return;
	}
	local company = this.GetCompanyByID(companyid);
	local diff = score - company.score_last_year; //pop increase during last year
	local Tpositive = diff > 0 ? GSText.STR_PLUS : GSText.STR_EMPTY0; //plus or minus sign?

	local newElementId = GSStoryPage.NewElement(
		this.story[0],
		GSStoryPage.SPET_LOCATION,
		GSCompany.GetCompanyHQ(companyid),
		GSText(GSText.STR_STORY_PROGRESS, this.current_year - 1, companyid, score, GSText(Tpositive), diff)
	);
	
	this.storyElement.append(newElementId);
	if(this.storyElement.len() > 24){
		foreach(id, element in this.storyElement){
			this.storyElement.remove(id);
			GSStoryPage.RemoveElement(element);
		  break;
		}
	}
}
/* /story page*/