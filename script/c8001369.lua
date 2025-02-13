-- Price of Power / 力の代償 / Le Prix du Pouvoir
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand if opponent controls more face-up monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Continuous Effect to Track Opponent's Monster Effects
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)

    -- Reset Flag at Start of Turn without interaction
    aux.GlobalCheck(s,function()
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_TURN_END)
        ge2:SetOperation(s.resetop)
        Duel.RegisterEffect(ge2,0)
    end)

    -- Destroy
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.condition)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end

function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if ep~=tp and re:IsActiveType(TYPE_MONSTER) then
        if Duel.GetFlagEffect(ep,id)<5 then
            Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ResetFlagEffect(tp,id)
    Duel.ResetFlagEffect(1-tp,id)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(1-tp,id)>=5 or (e:GetHandler():IsLocation(LOCATION_HAND) and s.handcon(e))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local count=Duel.GetMatchingGroupCount(Card.IsControler,tp,0,LOCATION_MZONE,nil,1-tp)
    if chk==0 then return count>0 and Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local options = {}
    for i=1, math.min(count,3) do
        table.insert(options, i)
    end
    local ct=Duel.AnnounceNumber(tp,table.unpack(options))
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
