-- ブラックロードの身代金 (Blacklord's Ransom)
local s, id = GetID()

function s.initial_effect(c)
    -- When activated: Banish 1 "Blacklord" monster from your Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2226))
	c:RegisterEffect(e1)

    -- Inflict damage when Special Summoning a "Blacklord" Synchro Monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.damcon)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Add 1 banished "Blacklord" card to your hand when this card leaves the field
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

function s.rmfilter(c)
    return c:IsSetCard(0x2226) and c:IsAbleToRemove()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_DECK)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.rmfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    end
end

function s.extg(e, c)
    return c:IsSetCard(0x2226)
end

function s.damfilter(c, tp)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp)
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.damfilter, 1, nil, tp)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1-tp, 100, REASON_EFFECT)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetLP(tp) > Duel.GetLP(1-tp) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end

function s.tdfilter(c)
    return c:IsSetCard(0x2226) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.tdfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end