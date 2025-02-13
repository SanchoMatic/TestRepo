-- Price of Silence / 沈黙の代償 / Le Prix du Silence
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand by paying half of owner's life points
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    c:RegisterEffect(e1)

    -- Inflict Damage and Destroy Defense Position Monsters
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    return g:FilterCount(function(c) return not c:IsType(TYPE_LINK) end, nil) > 0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
        if chk==0 then return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
        Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
    else
        if chk==0 then return true end
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and not c:IsType(TYPE_LINK) end,tp,0,LOCATION_MZONE,1,nil) end
    local dam=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetDefense)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local dam=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetDefense)
    Duel.Damage(1-tp,dam,REASON_EFFECT)
    local dg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.Destroy(dg,REASON_EFFECT)
end
