--黒・魔・導の啓示
-- Dark Magic Revelations
local s,id=GetID(100000726)
-- List the names of referenced cards
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- Destroy opponent's cards
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)  -- Hard once per turn limit
    c:RegisterEffect(e1)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,nil)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
    local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,ct,ct,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
        
        -- Ask the player if they want to reveal all face-down cards
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            -- Reveal all face-down cards
            local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            if #g2>0 then
                Duel.ConfirmCards(tp,g2)
                Duel.ConfirmCards(1-tp,g2)
                
                -- Provide a hint message to flip them back face-down when the player is ready
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
                if Duel.SelectOption(tp,aux.Stringid(id,3))==0 then -- Player presses OK to continue
                    -- Flip the cards back face-down
                    Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
                end
            end
        end
    end
end