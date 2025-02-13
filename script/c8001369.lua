-- Price of Power / 力の代償 / Le Prix du Pouvoir
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand if opponent controls more face-up monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Destroy
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.condition)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.GetMatchingGroupCount(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)>=5
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local count=Duel.GetMatchingGroupCount(Card.IsControler,tp,0,LOCATION_MZONE,nil,1-tp)
    if chk==0 then return count>0 and Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local ct=Duel.AnnounceNumber(tp,1,math.min(count,3))
    Duel.DiscardDeck(tp,ct,REASON_COST)
    e:SetLabel(ct)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=e:GetLabel() end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,e:GetLabel(),1-tp,LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,ct,ct,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
    if c:IsLocation(LOCATION_HAND) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
