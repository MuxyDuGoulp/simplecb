require("version.nut");

class AdminBot
{
	name = "";
	forwardlogtoadminport = true;
	
	constructor( )
	{
		this.name = "Goulp-Bot";
	}
	function HandleAdminEvent( event );
	function SendGSInfo( );
};

function AdminBot::ForwardLogAdminPort( bool )
{
	this.forwardlogtoadminport = bool;
}

function AdminBot::HandleAdminEvent( event )
{
	local adminevent = GSEventAdminPort.Convert(event);
	local adminobject = adminevent.GetObject( );
	foreach (key, value in adminobject) {
		this.SendGSLog( key + ":" + value);
		if ((key=="GSInfo") && (value==this.name)){
			this.SendGSLog( "GSInfo Requested" );
			this.SendGSInfo( );
		}
	}

}

function AdminBot::SendGSLog( logmessage )
{
	if(GSGame.IsMultiplayer()){
		if (this.forwardlogtoadminport) {
			local tosend = {GSLog = logmessage};
			GSLog.Info( "GSLog Sending " + logmessage + " To AdminPort" );
			if(!GSAdmin.Send(tosend))
				GSLog.Error("Error while sending logmessage to admin port");
		}
	}
}

function AdminBot::SendGSInfo( )
{

	local info = {};
	info.Author <- INFO_AUTHOR;
	info.Name <- INFO_NAME;
	info.Description <- INFO_DESCRIPTION;
	info.Version <- INFO_VERSION;
	info.Date <- INFO_DATE;
	info.ShortName <- INFO_SHORTNAME;
	info.APIVersion <- INFO_APIVERSION;
	info.Url <- INFO_URL;
	
	local infotosend = {};
	infotosend.GSInfo <- info;

	this.SendObjectToAdmin( infotosend );

}

function AdminBot::SendObjectToAdmin( object )
{
	GSLog.Info( "SendObjectToAdmin" );
	GSLog.Info( object );
	if(GSGame.IsMultiplayer()) {
		GSLog.Info( "SendObjectToAdmin:Multiplayergame Ok" );
		if(!GSAdmin.Send(object)) {
			GSLog.Error("Error while sending object to admin port");
		} else {
			GSLog.Info( "SendObjectToAdmin:sent" );
		}
	}
}
