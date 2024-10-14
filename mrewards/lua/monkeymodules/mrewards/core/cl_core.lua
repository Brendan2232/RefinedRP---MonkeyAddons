net.Receive( "MRewards:Reward:SendReward", function()

    local rewardID = net.ReadUInt( 20 )

    MRewards.CreateGUI( rewardID )

end )

