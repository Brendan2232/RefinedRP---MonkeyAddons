local AnnouncementInterval = CreateClientConVar( "refined_rp_announcement_interval", 60, true, false, "", 20, 120 )
local AnnouncementEnabled = CreateClientConVar( "refined_rp_enable_announcements", 1, true, false )

local announcementTitle = "{colorRed} RefinedRP {colorWhite} |"

local announcements = {

    "Do you have a complaint about a member of staff? Join the discord by using !discord, and make an admin complaint!",

  //  "Find the heart beat sound effect annoying? Use 'heart_beat_effect' 0 to disable it, or 'heart_beat_effect' to turn the sound effect down!",
        
    "Looking to join our staff team? Join the Discord by using !discord, and click the 'admin-application' channel.",

    "If you need help on the server, feel free to use @ with a short reason why so the staff team can help you.",

    "Wanting to buy VIP, Perma guns; or other stuff within the server? Use !donate, or you can find it within the tab menu.",

    "Did you know we have a custom unbox? Use !unbox and get yourself a perm CS:GO knife!",

    "Not familiar with the rules on the server? Use !rules to access the google doc containing all the rules on the server.",

    "We don't use a forum system, everything is done through our Discord server! Join by typing !discord",
}

local announcementIndex = 1 

local performAnnouncement = function()

    if ( not AnnouncementEnabled:GetBool() ) then return end 

    local foundMessage = announcements[announcementIndex]
    if ( not isstring( foundMessage ) ) then return end 

    MonkeyLib.ChatMessage( "%s %s", { announcementTitle, foundMessage } )

    announcementIndex = announcementIndex + 1 

    if ( announcementIndex > #announcements ) then 

        announcementIndex = 1 
    end 
end

local startAnnouncements = function()

    local announcementTime = AnnouncementInterval:GetInt() or 60 
    
    timer.Create( "MonkeyLib:Announcements", announcementTime, 0, performAnnouncement )
end

cvars.AddChangeCallback( "refined_rp_announcement_interval", function( name, old, new )

    timer.Adjust( "MonkeyLib:Announcements", new )
	
end, "RefinedRPAnnouncementInterval" )

startAnnouncements()

