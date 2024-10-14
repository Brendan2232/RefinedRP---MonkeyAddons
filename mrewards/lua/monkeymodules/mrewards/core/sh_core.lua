local function calculateRewards()

    local allRewards = MRewards.Rewards

    local sortedRewards = {}

    if ( istable( allRewards ) and #allRewards >= 1 ) then
        
        for k = 1, #allRewards do 

            local rewardData = allRewards[k]

            if ( not rewardData ) then 

                continue 
            end 

            local rewardAmount = rewardData.Amount

            if ( not isnumber( rewardAmount ) ) then 
                
                continue 
            end 

            for i = 1, rewardAmount do

                local index = #sortedRewards + 1 
                sortedRewards[index] = k 

            end

        end

    end

    return sortedRewards or {}
end

MRewards.IndexToReward = function( index )
    
    if ( not isnumber( index ) ) then return end 

    return MRewards.Rewards[index] or false 
end

hook.Protect( "Initialize", "MRewards:Init:CacheRewards", function()

    MRewards.SharedRewards = calculateRewards()

end )

