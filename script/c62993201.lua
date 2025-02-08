-- ブラックロードの炎撃チャー・レッド (Blacklord Blaze of Char-Red)
local s, id = GetID()

function s.initial_effect(c)
    -- Activate from hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Inflict damage by tributing a "Blacklord" monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O + EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_HAND + LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
    
    -- Special Summon a "Blacklord" Synchro Monster from banished or GY and inflict damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.handcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 837543), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.costfilter(c)
    return c:IsSetCard(0x2226) and c:IsReleasable()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.Release(g, REASON_COST)
    e:SetLabel(g:GetFirst():GetBaseAttack())
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, math.floor(e:GetLabel() / 2))
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1-tp, math.floor(e:GetLabel() / 2), REASON_EFFECT)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.Damage(1-tp, g:GetFirst():GetLevel() * 100, REASON_EFFECT)
    end
end