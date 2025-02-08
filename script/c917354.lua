-- ベラノワールの女王 (Bellanoire, Queen of the Blacklords)
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, nil, 1, 1, aux.FilterBoolFunction(Card.IsCode, 253676), 1, 1)
    
    -- Banish 1 card on the field
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.rmcon)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- Inflict damage if you control "Char-Red, King of the Blacklords"
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.dmgcon)
    e2:SetCost(s.dmgcost)
    e2:SetTarget(s.dmgtg)
    e2:SetOperation(s.dmgop)
    c:RegisterEffect(e2)
end

function s.rmcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
        if #g > 0 then
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
    end
end

function s.dmgcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 837543), tp, LOCATION_MZONE + LOCATION_EXTRA, 0, 1, nil)
end

function s.dmgcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TRIBUTE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.Release(g, REASON_COST)
    e:SetLabel(g:GetFirst():GetAttack() / 2)
end

function s.dmgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, e:GetLabel())
end

function s.dmgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1-tp, e:GetLabel(), REASON_EFFECT)
end

function s.cfilter(c)
    return c:IsRace(RACE_FIEND) or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON))
end