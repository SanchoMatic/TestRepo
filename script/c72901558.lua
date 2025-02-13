-- Price of Lies / 嘘の代償 / Le Prix du Mensonge
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand if you control less Set cards than your opponent
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Banish face-down card or random hand card
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)<Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)>=2
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) 
        or Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_HAND,1,nil) end
    local op=0
    if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) 
        and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_HAND,1,nil) then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) then
        op=Duel.SelectOption(tp,aux.Stringid(id,0))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
    else
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    else
        local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
        if #g>0 then
            local sg=g:RandomSelect(tp,1)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    end
end
