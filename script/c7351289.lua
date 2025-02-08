-- ブラックロードの堀 (Blacklord's Moat)
local s, id = GetID()

function s.initial_effect(c)
    -- Negate effect and inflict damage
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return ep ~= tp and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x2226), tp, LOCATION_MZONE, 0, 1, nil) and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, 1, nil, TYPE_SYNCHRO)
end

function s.costfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return re:GetHandler():IsAbleToRemove() end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0, 0)
    if re:GetHandler():IsType(TYPE_MONSTER) then
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, re:GetHandler():GetAttack())
    end
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Remove(eg, POS_FACEUP, REASON_EFFECT) ~= 0 then
        local tc = re:GetHandler()
        if tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_REMOVED) then
            Duel.Damage(1-tp, tc:GetAttack(), REASON_EFFECT)
        end
    end
end